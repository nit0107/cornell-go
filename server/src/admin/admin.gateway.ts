import { UseGuards } from '@nestjs/common';
import {
  MessageBody,
  SubscribeMessage,
  WebSocketGateway,
} from '@nestjs/websockets';
import { CallingUser } from 'src/auth/calling-user.decorator';
import { AdminGuard } from 'src/auth/jwt-auth.guard';
import { User } from 'src/model/user.entity';
import { AdminCallbackService } from './admin-callback/admin-callback.service';
import { UpdateAdminDataAdminDto } from './admin-callback/update-admin-data.dto';
import { AdminService } from './admin.service';
import { ClientService } from 'src/client/client.service';
import { RewardService } from 'src/reward/reward.service';
import { RequestAdminsDto } from './request-admins.dto';
import { RequestChallengesDto } from './request-challenges.dto';
import { RequestEventsDto } from './request-events.dto';
import { RequestRewardsDto } from './request-rewards.dto';
import { UpdateRewardDataDto } from './admin-callback/update-reward-data.dto';
import { UpdateAdminsDto } from './update-admins.dto';
import { UpdateChallengesDto } from './update-challenges.dto';
import { UpdateEventsDto } from './update-events.dto';
import { UpdateEventDataDto } from './admin-callback/update-event-data.dto';
import { UpdateRewardsDto } from './update-rewards.dto';
import { EventReward } from 'src/model/event-reward.entity';
import { v4 } from 'uuid';

@WebSocketGateway({ cors: true })
@UseGuards(AdminGuard)
export class AdminGateway {
  constructor(
    private clientService: ClientService,
    private adminService: AdminService,
    private rewardService: RewardService,
    private adminCallbackService: AdminCallbackService,
  ) {}

  @SubscribeMessage('requestEvents')
  async requestEvents(@CallingUser() user: User, data: RequestEventsDto) {}

  @SubscribeMessage('requestChallenges')
  async requestChallenges(
    @CallingUser() user: User,
    data: RequestChallengesDto,
  ) {}

  @SubscribeMessage('requestRewards')
  async requestRewards(@CallingUser() user: User, data: RequestRewardsDto) {
    const rewardData = await this.adminService.getRewardsForUser(user);

    const updateRewardData: UpdateRewardDataDto = {
      rewards: await Promise.all(
        rewardData.map(async (reward: EventReward) => {
          return {
            id: reward.id,
            description: reward.rewardDescription,
            redeemInfo: reward.rewardRedeemInfo,
            containingEventId: reward.containingEvent.id,
          };
        }),
      ),
      deletedIds: [],
    };
    this.adminCallbackService.emitUpdateRewardData(updateRewardData, user);
    return false;
  }

  @SubscribeMessage('requestAdmins')
  async requestAdmins(@CallingUser() user: User, data: RequestAdminsDto) {
    const admins = await this.adminService.getAllRequestingAdmins();
    // Only send to the requester
    this.adminCallbackService.emitUpdateAdminData({
      admins: admins.map(usr => ({
        id: usr.id,
        requesting: true,
        email: usr.email,
        superuser: usr.superuser,
      })),
    });
  }

  @SubscribeMessage('updateEvents')
  async updateEvents(@CallingUser() user: User, data: UpdateEventsDto) {}

  @SubscribeMessage('updateChallenges')
  async updateChallenges(
    @CallingUser() user: User,
    data: UpdateChallengesDto,
  ) {}

  @SubscribeMessage('updateRewards')
  async updateRewards(@CallingUser() user: User, data: UpdateRewardsDto) {
    await this.adminService.deleteRewards(data.deletedIds);
    const [oldEvents, newEvents] = await this.adminService.updateRewards(
      data.rewards,
    );

    const oldEventDto: UpdateEventDataDto = {
      events: oldEvents.map(event => ({
        id: event.id,
        requiredMembers: event.requiredMembers,
        skippingEnabled: event.skippingEnabled,
        isDefault: event.isDefault,
        name: event.name,
        description: event.description,
        rewardType: event.rewardType,
        indexable: event.indexable,
        time: event.time.toTimeString(),
        rewardIds: event.rewards.getIdentifiers(),
        challengeIds: event.challenges.getIdentifiers(),
      })),
      deletedIds: data.deletedIds,
    };

    this.adminCallbackService.emitUpdateEventData(oldEventDto);
    const newEventDto: UpdateEventDataDto = {
      events: newEvents.map(event => ({
        id: event.id,
        requiredMembers: event.requiredMembers,
        skippingEnabled: event.skippingEnabled,
        isDefault: event.isDefault,
        name: event.name,
        description: event.description,
        rewardType: event.rewardType,
        indexable: event.indexable,
        time: event.time.toTimeString(),
        rewardIds: event.rewards.getIdentifiers(),
        challengeIds: event.challenges.getIdentifiers(),
      })),
      deletedIds: data.deletedIds,
    };
    this.adminCallbackService.emitUpdateEventData(newEventDto);
    const updatedDto: UpdateRewardDataDto = {
      rewards: data.rewards,
      deletedIds: data.deletedIds,
    };
    this.adminCallbackService.emitUpdateRewardData(updatedDto);
  }

  @SubscribeMessage('updateAdmins')
  async updateAdmins(@CallingUser() user: User, data: UpdateAdminsDto) {
    const adminUpdates: UpdateAdminDataAdminDto[] = [];
    for (const adminData of data.adminUpdates) {
      const admin = await this.adminService.setAdminStatus(
        adminData.id,
        adminData.granted,
      );
      if (admin) {
        adminUpdates.push({
          id: admin.id,
          email: admin.email,
          requesting: false,
          superuser: admin.superuser,
        });
      }
    }
    // Send to all that an admin was updated
    this.adminCallbackService.emitUpdateAdminData({ admins: adminUpdates });
  }
}
